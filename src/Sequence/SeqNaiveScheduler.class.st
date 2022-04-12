Class {
	#name : #SeqNaiveScheduler,
	#superclass : #SeqScheduler,
	#instVars : [
		'completedFrames'
	],
	#category : #Sequence
}

{ #category : #accessing }
SeqNaiveScheduler >> completedFrames [
	^completedFrames
]

{ #category : #accessing }
SeqNaiveScheduler >> runDumbFor: aDuration [
	| frame advance elapsed blockStream |
	"Naive execution is plain simple: just trigger blocks in the topological order
	until the time ends. Resources always must be available (otherwise it is a misconfig)"
	completedFrames := 0.
	elapsed := 0 seconds.
	advance := [	frame := self input next.
					frame timestamp: elapsed.
					blockStream := ReadStream on: (self sequence tasksFor: frame)].
	"Initiate processing of the first frame"
	advance value.
	"Run the simulation loop. Note it combines both frames and blocks (per frame)"
	[ elapsed < aDuration ] whileTrue: [ | thisBlock token | 
		blockStream atEnd ifTrue: advance.
		thisBlock := blockStream next.
		token := thisBlock target tryLock: thisBlock at: elapsed inContextOf: frame.
		token ifNil: [ self error: 'Should never happen, please check our resource allocation' ].
		thisBlock target release: token.
		elapsed := elapsed + (thisBlock durationOn: frame)].
	"If the execution time is over AND the block stream is over, there was one more frame completed"
	completedFrames := blockStream atEnd
		ifTrue: [frame id + 1]
		ifFalse: [frame id].
]

{ #category : #accessing }
SeqNaiveScheduler >> runFor: aDuration [
	self sequence hasLiveSource
		ifTrue: [ self runLiveFor: aDuration ]
		ifFalse: [ self runDumbFor: aDuration ]
]

{ #category : #accessing }
SeqNaiveScheduler >> runLiveFor: aDuration [
	| frame pendingFrames elapsed streams blockStream liveStream liveBlock opBlocks |
	"Naive execution is plain simple: just trigger blocks in the topological order
	until the time ends. Resources always must be available (otherwise it is a misconfig)"
	frame := nil.
	completedFrames := 0.
	elapsed := 0 seconds.
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
	
   [ elapsed < aDuration ] whileTrue: [	| blocksToPick nextTick |
		streams do: [ :each | each updateTimePoint: elapsed ].
		blocksToPick := (streams select: [:each | each canWork]) asSortedCollection: [ :b1 :b2 | b1 nextTick < b2 nextTick ].
		nextTick := blocksToPick first nextTick.
		(blocksToPick select: [ :each | each nextTick = nextTick ]) do: [ :each | each advance ].
		self assert: nextTick >= elapsed.
		elapsed := nextTick].
	
	"FIXME: Ugly kludge"
	opBlocks ifEmpty: [ completedFrames := pendingFrames asArray size ].

]
