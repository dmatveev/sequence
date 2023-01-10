Class {
	#name : #SeqMultiExecutor,
	#superclass : #SeqExecutor,
	#instVars : [
		'elapsed',
		'completedFrames',
		'latencies',
		'starts',
		'droppedFrames'
	],
	#category : #Sequence
}

{ #category : #accessing }
SeqMultiExecutor >> add: aSequence [
	self add: aSequence with: [ ]

]

{ #category : #accessing }
SeqMultiExecutor >> add: aSequence with: anInputStreamBlock [
	self subclassResponsibility
]

{ #category : #accessing }
SeqMultiExecutor >> counters: aSequence [
	"Generate execution counters based on what we've registered"
	| counters frames dropped |
	counters := Dictionary new.
	frames := completedFrames at: aSequence ifAbsent: [0].
	dropped := droppedFrames at: aSequence ifAbsent: [0].
	counters at: #latencyAverage put:
		(frames > 0 ifTrue: [(latencies at: aSequence) average] ifFalse: [0 ms]).
	counters at: #latencyMedian put:
		(frames > 0 ifTrue: [(latencies at: aSequence) median] ifFalse: [0 ms]).
	counters at: #latencyMax put:
		(frames > 0 ifTrue: [(latencies at: aSequence) max] ifFalse:  [0 ms]).
	counters at: #completedFrames put: frames.
	counters at: #droppedFrames put: dropped.
	^counters
]

{ #category : #accessing }
SeqMultiExecutor >> initialize [
	super initialize.
	completedFrames := Dictionary new.
	droppedFrames := Dictionary new.
	latencies := Dictionary new.
	starts := Dictionary new.
	elapsed := 0 ms.
]

{ #category : #accessing }
SeqMultiExecutor >> register: aSequence [
	latencies at: aSequence put: OrderedCollection new.
]

{ #category : #accessing }
SeqMultiExecutor >> registerCompleted: aSequence at: aTimePoint [
	| startPoint |
	completedFrames at: aSequence update: [:n | n + 1].
	startPoint := starts removeKey: aSequence.
	(latencies at: aSequence) add: (aTimePoint - startPoint).
]

{ #category : #accessing }
SeqMultiExecutor >> registerDropped: aSequence [
	droppedFrames at: aSequence update: [ :x | x + 1 ] initial: [ 1 ].
]

{ #category : #accessing }
SeqMultiExecutor >> registerStarted: aSequence at: aTimePoint [
	starts at: aSequence put: aTimePoint.
]
