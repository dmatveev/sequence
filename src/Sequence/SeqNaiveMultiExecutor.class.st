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
	
	"Short-cut: if pipelineing option is selected, add it this way"
	firstBlock := aSequence topoSorted first.
	opBlocks := aSequence topoSorted allButFirst.
	(seqExecOptions hasPipeliningEnabled and: (opBlocks size > 1)) ifTrue: [ ^self addPipeline: aSequence topoSorted options: seqExecOptions ].

	"Add stream(s) associated with the sequence to the executor."
	(firstBlock isLive and: opBlocks isEmpty) ifTrue: [ ^self addLiveStream: firstBlock options: seqExecOptions ].
	(firstBlock isLive and: opBlocks isNotEmpty) ifTrue: [ ^self addLiveStream: firstBlock withOpStream: opBlocks options: seqExecOptions ].
	firstBlock isLive ifFalse: [ ^self addOpStream: aSequence topoSorted options: seqExecOptions ].
	
	"If reached here, something is wrong."
	self error: 'Don''t know how to handle such sequence'.
]

{ #category : #compatibility }
SeqNaiveMultiExecutor >> add: aSequence priority: aNumber [
	^self add: aSequence with: [] priority: aNumber
]

{ #category : #compatibility }
SeqNaiveMultiExecutor >> add: aSequence priority: aNumber dropFrames: dropFrames [
	| o |
	o := SeqExecOptions new.
	o priority: aNumber.
	dropFrames ifTrue: [ o dropFrames ].
	^self add: aSequence options: o.
]

{ #category : #compatibility }
SeqNaiveMultiExecutor >> add: aSequence with: anInputStreamBlock [
	^self add: aSequence with: anInputStreamBlock priority: 0
]

{ #category : #compatibility }
SeqNaiveMultiExecutor >> add: aSequence with: anInputStreamBlock options: options [
	"Yen another short-cut"
	options
		inputStream: (SeqFrameSource using: anInputStreamBlock for: aSequence).
	^self add: aSequence options: options. 
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
		priority: aNumber;
		scheduler: self scheduler.
	streams add: liveStream.
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
		priority: aNumber;
		scheduler: self scheduler.
	streams add: liveStream.
	
	blockStream := SeqEventStream on: opBlocks.
	blockStream
		canStartTest: [ pendingFrames isEmpty not ];
		onStart: [seqExecOptions framePolicy handleStart: blockStream exec: self pending: pendingFrames ];
		onComplete: [ self registerCompleted: anInputStream sequence on: blockStream thisFrame at: blockStream currentTime ];
		priority: aNumber;
		scheduler: self scheduler.
	streams add: blockStream.
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
			self registerStarted: anInputStream sequence on: frame at: blockStream currentTime ];
		onComplete: [ self registerCompleted: anInputStream sequence on: blockStream thisFrame at: blockStream currentTime ];
		priority: aNumber;
		scheduler: self scheduler.
	streams add: blockStream.
]

{ #category : #private }
SeqNaiveMultiExecutor >> addPipeline: allBlocks options: seqExecOptions [
	| inputFrame liveStream pendingInputFrames mail |
	
	"Validate if we can support this case. So far the support is fairly limited (only linked-list-like
	pipeliens)"
	allBlocks first isLive ifFalse: [ SeqLiveSourceMustBeFirst new signal ].
	allBlocks do: [ :each | (each producers size > 1 or: (each consumers size > 1))
		ifTrue: [ self error: 'Only linked-list-like sequences supported for pipelining simulation' ] ]. "FIXME: Exception!"
		
	"Set-up the live stream first."
	"NOTE: This is an exact copy of other addLive... options"
	pendingInputFrames := DoubleLinkedList new.
	liveStream := SeqEventStream with: allBlocks first.
	liveStream
		canStartTest: [ true ];
		onStart: [
			inputFrame := seqExecOptions inputStream next.
			inputFrame timestamp: elapsed. "FIXME: Shouldn't this be liveStream currentTime as in below?"
			liveStream updateFrame: inputFrame ];
		onComplete: [ 
			inputFrame availableSince: liveStream currentTime. "FIXME: Must be propagated to other #add:"
			pendingInputFrames add: inputFrame ];
		priority: seqExecOptions priority;
		scheduler: self scheduler.
	streams add: liveStream.
	
	"Initialize mailboxes... A dumb way to communicate between pipeline steps"
	mail := Dictionary new.
	allBlocks allButFirst do: [ :each | mail at: each put: (SeqMailbox options: seqExecOptions) ].
	
	"Set-up the first operation then. Note: it is special as it may drop frames."
	allBlocks second streams timesRepeat: [ | firstBlockStream | 
	firstBlockStream := SeqEventStream with: allBlocks second.
	firstBlockStream
		canStartTest: [ pendingInputFrames isEmpty not and: (mail at: allBlocks second consumers anyOne) hasFreeSpace ];
		onStart:      [ seqExecOptions framePolicy handleStart: firstBlockStream exec: self pending: pendingInputFrames ];
		onComplete:   [ (mail at: allBlocks second consumers anyOne) put: firstBlockStream thisFrame ];
			"FIXME: There may be race between instances (data overwritten before read). Fortunately #put: handles collision"
		priority: seqExecOptions priority;
		scheduler: self scheduler.
	streams add: firstBlockStream].
	
	"Set-up interim operations"
	streams addAll: ((allBlocks copyFrom: 3 to: allBlocks size - 1) collect: [ :each |
		(1 to: each streams) collect: [:u || workerStream |
		workerStream := SeqEventStream with: each.
		workerStream 
			canStartTest: [ (mail at: each) hasContent and: (mail at: each consumers anyOne) hasFreeSpace ];
			onStart:      [ workerStream updateFrame: (mail at: each) takeOne ];
			onComplete:   [ (mail at: each consumers anyOne) put: workerStream thisFrame ];
				"FIXME: There may be race between instances (data overwritten before read). Fortunately #put: handles collision"
			priority: seqExecOptions priority;
			scheduler: self scheduler;
			yourself]]) flattened. "FIMXE: Refactor!!!"

	"Set-up the last (completer) stream"
	allBlocks last streams timesRepeat: [ | lastBlockStream |
	lastBlockStream := SeqEventStream with: allBlocks last.
	lastBlockStream
		canStartTest: [ (mail at: allBlocks last) hasContent ];
		onStart:      [ lastBlockStream updateFrame: (mail at: allBlocks last) takeOne. ];
		onComplete:   [ self registerCompleted: seqExecOptions sequence on: lastBlockStream thisFrame at: lastBlockStream currentTime  ];
		priority: seqExecOptions priority;
		scheduler: self scheduler.
	streams add: lastBlockStream].
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
	scheduler := aScheduler.
	"If streams have been added already, propagate a new one down to them"
	streams do: [ :each | each scheduler: aScheduler ]
]

{ #category : #accessing }
SeqNaiveMultiExecutor >> trace [
	| trace |
	trace := SeqTrace new.
	"FIXME: The below construction is not that classy"
	sequences do: [ :seq | trace add: seq over: (self counters: seq) ].
	trace showLabels.
	^trace
]
