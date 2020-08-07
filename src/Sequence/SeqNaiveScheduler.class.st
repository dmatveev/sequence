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
	| thisFrame elapsed stream |
	"Naive execution is plain simple: just trigger blocks in the topological order
	until the time ends. Resources always must be available (otherwise it is a misconfig)"
	thisFrame := 0.
	elapsed := 0 seconds.
	stream := ReadStream on: topo.
	[ elapsed < aDuration ] whileTrue: [ | thisBlock token | 
		stream atEnd ifTrue: [
			stream reset.
			completedFrames := thisFrame + 1.
			thisFrame := thisFrame + 1].
		thisBlock := stream next.
		token := thisBlock target tryLock: thisBlock at: elapsed inContextOf: thisFrame.
		token ifNil: [ self error: 'Should never happen, please check our resource allocation' ].
		thisBlock target release: token.
		elapsed := elapsed + thisBlock duration].
	"If the execution time is over AND the stream is over, there was one more frame completed"
	stream atEnd ifTrue: [ completedFrames := completedFrames + 1 ].	
]
