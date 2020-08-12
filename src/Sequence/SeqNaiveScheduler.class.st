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
SeqNaiveScheduler >> runFor: aDuration [
	| frame advance elapsed stream |
	"Naive execution is plain simple: just trigger blocks in the topological order
	until the time ends. Resources always must be available (otherwise it is a misconfig)"
	completedFrames := 0.
	elapsed := 0 seconds.
	advance := [	frame := self input next.
					frame timestamp: elapsed.
					stream := ReadStream on: (self sequence tasksFor: frame)].
	advance value.
	[ elapsed < aDuration ] whileTrue: [ | thisBlock token | 
		stream atEnd ifTrue: advance.
		thisBlock := stream next.
		token := thisBlock target tryLock: thisBlock at: elapsed inContextOf: frame.
		token ifNil: [ self error: 'Should never happen, please check our resource allocation' ].
		thisBlock target release: token.
		elapsed := elapsed + thisBlock duration].
	"If the execution time is over AND the stream is over, there was one more frame completed"
	completedFrames := stream atEnd
		ifTrue: [frame id + 1]
		ifFalse: [frame id].
]
