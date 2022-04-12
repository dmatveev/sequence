Class {
	#name : #SeqNaiveScheduler,
	#superclass : #SeqMonoScheduler,
	#instVars : [
		'completedFrames',
		'frame',
		'elapsed'
	],
	#category : #Sequence
}

{ #category : #accessing }
SeqNaiveScheduler >> completedFrames [
	^completedFrames
]

{ #category : #accessing }
SeqNaiveScheduler >> initialize [
	super initialize.
	elapsed := 0 seconds.
	completedFrames := 0.
]

{ #category : #accessing }
SeqNaiveScheduler >> runDumbFor: aDuration [
	| blockStream nextFrameBlock |
	"Naive execution is plain simple: just trigger blocks in the topological order
	until the time ends. Resources always must be available (otherwise it is a misconfig)"
		
	blockStream := SeqEventStream on: sequence topoSorted.
	nextFrameBlock := [ 
		frame := self input next.
		frame timestamp: elapsed.
		blockStream updateFrame: frame].
	blockStream
		canStartTest: [ true ];
		onStart: nextFrameBlock;
		onComplete: [ completedFrames := completedFrames + 1 ].
	self runEventStreams: {blockStream} for: aDuration.

]

{ #category : #private }
SeqNaiveScheduler >> runEventStreams: anArray for: aDuration [
	"This is the main simulation loop.
	Should work uniformly for all cases"
   [ elapsed < aDuration ] whileTrue: [	| blocksToPick nextTick |
		anArray do: [ :each | each updateTimePoint: elapsed ].
		blocksToPick := (anArray select: [:each | each canWork]) asSortedCollection: [ :b1 :b2 | b1 nextTick < b2 nextTick ].
		nextTick := blocksToPick first nextTick.
		(blocksToPick select: [ :each | each nextTick = nextTick ]) do: [ :each | each advance ].
		self assert: nextTick >= elapsed.
		elapsed := nextTick].
]

{ #category : #accessing }
SeqNaiveScheduler >> runFor: aDuration [
	self sequence hasLiveSource
		ifTrue: [ self runLiveFor: aDuration ]
		ifFalse: [ self runDumbFor: aDuration ]
]

{ #category : #accessing }
SeqNaiveScheduler >> runLiveFor: aDuration [
	| pendingFrames streams blockStream liveStream liveBlock opBlocks |

	pendingFrames := DoubleLinkedList new.
	liveBlock := self sequence topoSorted first.
	opBlocks := self sequence topoSorted allButFirst.
	streams := OrderedCollection new.
	
	liveStream := SeqEventStream with: liveBlock.
	liveStream
		canStartTest: [ true ];
		onStart: [
			frame := self input next.
			frame timestamp: elapsed.
			liveStream updateFrame: frame ];
		onComplete: [ pendingFrames add: frame ].
	streams add: liveStream.
	opBlocks ifNotEmpty: [ 
		blockStream := SeqEventStream on: opBlocks.
		blockStream
			canStartTest: [ pendingFrames head isNotNil ];
			onStart: [
				blockStream updateFrame: pendingFrames first.
				pendingFrames removeFirst ];
			onComplete: [ completedFrames := completedFrames + 1 ].
		streams add: blockStream].
	self runEventStreams: streams for: aDuration.

	"FIXME: Ugly kludge"
	opBlocks ifEmpty: [ completedFrames := pendingFrames asArray size ].

]
