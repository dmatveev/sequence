Class {
	#name : #SeqNaiveMultiExecutor,
	#superclass : #SeqMultiExecutor,
	#instVars : [
		'streams',
		'scheduler'
	],
	#category : #Sequence
}

{ #category : #'as yet unclassified' }
SeqNaiveMultiExecutor class >> run: aCollectionOfSequences for: aDuration [
	^self new run: aCollectionOfSequences  for: aDuration

]

{ #category : #private }
SeqNaiveMultiExecutor >> add: aSequence with: anInputStreamBlock [
	| frame inputStream pendingFrames blockStream liveStream liveBlock opBlocks |

	"So far only handle the live case"
	self assert: aSequence topoSorted first isLive.
	completedFrames at: aSequence put: 0.
	inputStream := SeqFrameSource using: anInputStreamBlock for: aSequence.

	pendingFrames := DoubleLinkedList new.
	liveBlock := aSequence topoSorted first.
	opBlocks := aSequence topoSorted allButFirst.
	
	"Live block-only sequences are also not supported"
	self assert: opBlocks notEmpty.
	
	"FIXME: this is a total copy of the SeqNaiveScheduler parts."
	liveStream := SeqEventStream with: liveBlock.
	liveStream
		canStartTest: [ true ];
		onStart: [
			frame := inputStream next.
			frame timestamp: elapsed. "FIXME: Shouldn't this be liveStream currentTime as in below?"
			liveStream updateFrame: frame ];
		onComplete: [ pendingFrames add: frame ].
	streams add: liveStream.

	"FIXME: this is a total copy of the SeqNaiveScheduler parts"
	blockStream := SeqEventStream on: opBlocks.
	blockStream
		canStartTest: [ pendingFrames isEmpty not ];
		onStart: [
			blockStream updateFrame: pendingFrames first.
			pendingFrames removeFirst.
			self registerStarted: aSequence at: blockStream currentTime ];
		onComplete: [ self registerCompleted: aSequence at: blockStream currentTime ].
	streams add: blockStream.
	self register: aSequence.
]

{ #category : #initialization }
SeqNaiveMultiExecutor >> initialize [
	super initialize.
	streams := OrderedCollection new.
]

{ #category : #modelling }
SeqNaiveMultiExecutor >> run: aCollectionOfSequences for: aDuration [
	"Shouldn't be mixed with other (manual) path"
	self assert: streams isEmpty.

	aCollectionOfSequences do: [ :each | self add: each ].
	self runFor: aDuration.
	^self trace
]

{ #category : #private }
SeqNaiveMultiExecutor >> runFor: aDuration [
	"This is the main simulation loop.
	Should work uniformly for all cases.
	THIS is a total copy of the SeqNaiveSchedulerMethod. Should be unified among them somehow.
	The only change: it advances only one block at a time.
	The other change: it delegates block execution to the scheduler"
   [ elapsed < aDuration ] whileTrue: [	| streamsToPick nextStream nextTick |
		streams do: [ :each | each updateTimePoint: elapsed ].
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

{ #category : #accessing }
SeqNaiveMultiExecutor >> scheduler: aScheduler [
	scheduler := aScheduler
]

{ #category : #modelling }
SeqNaiveMultiExecutor >> trace [
	| trace |
	trace := SeqTrace new.
	"FIXME: The below construction is not that classy"
	latencies keysDo: [ :seq | trace add: seq over: (self counters: seq) ].
	^trace
]
