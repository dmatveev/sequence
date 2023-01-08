Class {
	#name : #SeqNaiveMultiExecutor,
	#superclass : #SeqMultiExecutor,
	#instVars : [
		'streams',
		'scheduler',
		'sequences'
	],
	#category : #Sequence
}

{ #category : #'as yet unclassified' }
SeqNaiveMultiExecutor class >> run: aCollectionOfSequences for: aDuration [
	^self new run: aCollectionOfSequences  for: aDuration

]

{ #category : #configuration }
SeqNaiveMultiExecutor >> add: aSequence options: seqExecOptions [
	|  firstBlock opBlocks |

	self checkIfCanHandle: aSequence.
	self register: aSequence.
	sequences add: aSequence. "NB: Shouldn't this be combined with #register?"
	completedFrames at: aSequence put: 0. "NB. Why on Earth I do this manually here.."
	
	"FIXME: Sheer ugliness."
	seqExecOptions sequence: aSequence.
	
	"Add stream(s) associated with the sequence to the executor."
	firstBlock := aSequence topoSorted first.
	opBlocks := aSequence topoSorted allButFirst.
	(firstBlock isLive and: opBlocks isEmpty) ifTrue: [ ^self addLiveStream: firstBlock options: seqExecOptions ].
	(firstBlock isLive and: opBlocks isNotEmpty) ifTrue: [ ^self addLiveStream: firstBlock withOpStream: opBlocks options: seqExecOptions ].
	firstBlock isLive ifFalse: [ ^self addOpStream: aSequence topoSorted options: seqExecOptions ].
	
	"If reached here, something is wrong."
	self error: 'Don''t know how to handle such sequence'.
]

{ #category : #configuration }
SeqNaiveMultiExecutor >> add: aSequence priority: aNumber [
	^self add: aSequence with: [] priority: aNumber
]

{ #category : #configuration }
SeqNaiveMultiExecutor >> add: aSequence priority: aNumber dropFrames: dropFrames [
	| o |
	o := SeqExecOptions new.
	o priority: aNumber.
	dropFrames ifTrue: [ o dropFrames ].
	^self add: aSequence options: o.
]

{ #category : #configuration }
SeqNaiveMultiExecutor >> add: aSequence with: anInputStreamBlock [
	^self add: aSequence with: anInputStreamBlock priority: 0
]

{ #category : #compatibility }
SeqNaiveMultiExecutor >> add: aSequence with: anInputStreamBlock priority: aPriority [
	| options |
	options := SeqExecOptions new.
	options
		inputStream: (SeqFrameSource using: anInputStreamBlock for: aSequence);
		priority: aPriority.
	^self add: aSequence options: options. 
]

{ #category : #private }
SeqNaiveMultiExecutor >> addLiveStream: aLiveBlock options: seqExecOptions [
	| frame liveStream anInputStream aNumber |

	anInputStream := seqExecOptions inputStream.
	aNumber := seqExecOptions priority.

	liveStream := SeqEventStream with: aLiveBlock.
	liveStream
		canStartTest: [ true ];
		onStart: [
			frame := anInputStream next.
			frame timestamp: elapsed. "FIXME: Shouldn't this be liveStream currentTime as in below?"
			liveStream updateFrame: frame ];
		onComplete: [];
		priority: aNumber.
	streams add: liveStream.
]

{ #category : #compatibility }
SeqNaiveMultiExecutor >> addLiveStream: aLiveBlock with: anInputStream priority: aNumber [
	^self
		addLiveStream: aLiveBlock
		options: (SeqExecOptions new inputStream: anInputStream; priority: aNumber; yourself). 
]

{ #category : #private }
SeqNaiveMultiExecutor >> addLiveStream: aLiveBlock withOpStream: opBlocks options: seqExecOptions [
	| frame liveStream pendingFrames blockStream anInputStream aNumber |

	pendingFrames := DoubleLinkedList new.
	anInputStream := seqExecOptions inputStream.
	aNumber := seqExecOptions priority.

	liveStream := SeqEventStream with: aLiveBlock.
	liveStream
		canStartTest: [ true ];
		onStart: [
			frame := anInputStream next.
			frame timestamp: elapsed. "FIXME: Shouldn't this be liveStream currentTime as in below?"
			liveStream updateFrame: frame ];
		onComplete: [ 
			frame availableSince: liveStream currentTime. "FIXME: Must be propagated to other #add:"
			pendingFrames add: frame ];
		priority: aNumber.
	streams add: liveStream.
	
	blockStream := SeqEventStream on: opBlocks.
	blockStream
		canStartTest: [ pendingFrames isEmpty not ];
		onStart: [
			seqExecOptions hasFrameDropAllowed
				ifFalse: [
					"Just take next frame to process and proceed"
					blockStream updateFrame: pendingFrames first.
					pendingFrames removeFirst.
					self registerStarted: anInputStream sequence at: blockStream currentTime ]
				ifTrue: [
					"Implement simple frame-dropping right here, if needed."				
					"If there's > 1 frame, mark all but last as dropped already."
					pendingFrames asArray allButLastDo: [ :each |
						each markDropped.
						self registerDropped: anInputStream sequence ].
					pendingFrames last availableSince = blockStream currentTime
						ifFalse: [
							pendingFrames last markDropped. "Late for this too. Drop & do nothing"
							self registerDropped: anInputStream sequence ] 
						ifTrue: [ 
							blockStream updateFrame: pendingFrames last.
							self registerStarted: anInputStream sequence at: blockStream currentTime ] ].
					pendingFrames removeAll];
		onComplete: [ self registerCompleted: anInputStream sequence at: blockStream currentTime ];
		priority: aNumber.
	streams add: blockStream.
]

{ #category : #compatibility }
SeqNaiveMultiExecutor >> addLiveStream: aLiveBlock withOpStream: opBlocks with: anInputStream priority: aNumber [
	^self
		addLiveStream: aLiveBlock
		withOpStream: opBlocks
		options: (SeqExecOptions new inputStream: anInputStream; priority: aNumber; yourself)
]

{ #category : #private }
SeqNaiveMultiExecutor >> addOpStream: opBlocks options: seqBlockOptions [
	| blockStream anInputStream aNumber |
	anInputStream := seqBlockOptions inputStream.
	aNumber := seqBlockOptions priority.

	blockStream := SeqEventStream on: opBlocks.
	blockStream
		canStartTest: [ true ];
		onStart: [
			| frame |
			frame := anInputStream next.
			frame timestamp: elapsed. "FIXME: or currentTime?"
			blockStream updateFrame: frame.
			self registerStarted: anInputStream sequence at: blockStream currentTime ];
		onComplete: [ self registerCompleted: anInputStream sequence at: blockStream currentTime ];
		priority: aNumber.
	streams add: blockStream.
]

{ #category : #compatibility }
SeqNaiveMultiExecutor >> addOpStream: opBlocks with: anInputStream priority: aNumber [
	^self
		addOpStream: opBlocks
		options: (SeqExecOptions new inputStream: anInputStream; priority: aNumber; yourself). 

]

{ #category : #private }
SeqNaiveMultiExecutor >> checkIfCanHandle: aSequence [
	"FIXME: Probably this method shouldn't exist. If a Sequence has been created,
	any executor should be able to handle it."
	self assert: (aSequence topoSorted select: [ :each | each isLive ]) size <= 1.
]

{ #category : #initialization }
SeqNaiveMultiExecutor >> initialize [
	super initialize.
	streams := OrderedCollection new.
	sequences := OrderedCollection new.
]

{ #category : #modelling }
SeqNaiveMultiExecutor >> run: aCollectionOfSequences for: aDuration [
	"Shouldn't be mixed with other (manual) path"
	self assert: streams isEmpty.
	self assert: sequences isEmpty.

	aCollectionOfSequences do: [ :each | self add: each ].
	self runFor: aDuration.
	^self trace
]

{ #category : #modelling }
SeqNaiveMultiExecutor >> runFor: aDuration [
	"This is the main simulation loop.
	Should work uniformly for all cases.
	THIS is a total copy of the SeqNaiveSchedulerMethod. Should be unified among them somehow.
	The only change: it advances only one block at a time.
	The other change: it delegates block execution to the scheduler"
   [ elapsed < aDuration ] whileTrue: [	| streamsToPick nextStream nextTick |
		streams do: [ :each | each updateTimePoint: elapsed ].
		"Note streams are the parallel threads of execution here, so dont get confused with the below ordering"
		streamsToPick := (streams select: [:each | each canWork]) asSortedCollection: [ :b1 :b2 | b1 nextTick < b2 nextTick ].
		nextStream := self scheduler decide: streamsToPick.
		nextTick := nextStream nextTick.
		self assert: nextTick >= elapsed.
		nextStream advance.
		elapsed := nextTick].
]

{ #category : #accessing }
SeqNaiveMultiExecutor >> scheduler [
	^scheduler ifNil: [ scheduler := SeqDumbScheduler new ]
]

{ #category : #configuration }
SeqNaiveMultiExecutor >> scheduler: aScheduler [
	scheduler := aScheduler
]

{ #category : #accessing }
SeqNaiveMultiExecutor >> trace [
	| trace |
	trace := SeqTrace new.
	"FIXME: The below construction is not that classy"
	sequences do: [ :seq | trace add: seq over: (self counters: seq) ].
	^trace
]
