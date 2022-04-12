Class {
	#name : #SeqNaiveMultiExecutor,
	#superclass : #SeqMultiExecutor,
	#instVars : [
		'streams'
	],
	#category : #Sequence
}

{ #category : #'as yet unclassified' }
SeqNaiveMultiExecutor class >> run: aCollectionOfSequences for: aDuration [
	| sched trace |
	sched := self new.
	aCollectionOfSequences do: [ :each | sched add: each ].
	sched runFor: aDuration.
	trace := SeqTrace new.
	aCollectionOfSequences do: [ :each | trace add: each over: (sched counters: each) ].
	^trace
]

{ #category : #accessing }
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
			frame timestamp: elapsed.
			liveStream updateFrame: frame ];
		onComplete: [ pendingFrames add: frame ].
	streams add: liveStream.

	"FIXME: this is a total copy of the SeqNaiveScheduler parts"
	blockStream := SeqEventStream on: opBlocks.
	blockStream
		canStartTest: [ pendingFrames head isNotNil ];
		onStart: [
			blockStream updateFrame: pendingFrames first.
			pendingFrames removeFirst.
			self registerStarted: aSequence at: blockStream currentTime ];
		onComplete: [ self registerCompleted: aSequence at: blockStream currentTime ].
	streams add: blockStream.
	self register: aSequence.
]

{ #category : #accessing }
SeqNaiveMultiExecutor >> initialize [
	super initialize.
	streams := OrderedCollection new.
]

{ #category : #accessing }
SeqNaiveMultiExecutor >> runFor: aDuration [
	"This is the main simulation loop.
	Should work uniformly for all cases.
	THIS is a total copy of the SeqNaiveSchedulerMethod. Should be unified among them somehow.
	The only change: it advances only one block at a time"
   [ elapsed < aDuration ] whileTrue: [	| blocksToPick nextTick |
		streams do: [ :each | each updateTimePoint: elapsed ].
		blocksToPick := (streams select: [:each | each canWork]) asSortedCollection: [ :b1 :b2 | b1 nextTick < b2 nextTick ].
		nextTick := blocksToPick first nextTick.
		"(blocksToPick select: [ :each | each nextTick = nextTick ]) do: [ :each | each advance ]."
		self assert: nextTick >= elapsed.
		blocksToPick first advance.
		elapsed := nextTick].
]
