Class {
	#name : #SeqMultiExecutor,
	#superclass : #SeqExecutor,
	#instVars : [
		'elapsed',
		'completedFrames',
		'latencies',
		'starts',
		'droppedFrames',
		'outputLatencies',
		'lastOutputs'
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
	counters at: #latencyAverage put: (frames > 0 ifTrue: [(latencies at: aSequence) average] ifFalse: [0 ms]).
	counters at: #latencyMedian  put: (frames > 0 ifTrue: [(latencies at: aSequence) median]  ifFalse: [0 ms]).
	counters at: #latencyMax     put: (frames > 0 ifTrue: [(latencies at: aSequence) max]     ifFalse: [0 ms]).
	counters at: #outputAverage  put: (frames > 0 ifTrue: [(outputLatencies at: aSequence) average] ifFalse: [ 0 ms ]).
	counters at: #outputMedian   put: (frames > 0 ifTrue: [(outputLatencies at: aSequence) median]  ifFalse: [ 0 ms ]).
	counters at: #outputMax      put: (frames > 0 ifTrue: [(outputLatencies at: aSequence) max]     ifFalse: [ 0 ms ]).
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
	outputLatencies := Dictionary new.
	lastOutputs := Dictionary new.
	"FIXME: Too much counters. Maybe can replaced with a counters structure
	and a single Dictionary (Sequence -> Counters)"
	elapsed := 0 ms.
]

{ #category : #accessing }
SeqMultiExecutor >> register: aSequence [
	latencies at: aSequence put: OrderedCollection new.
	starts at: aSequence put: Dictionary new.
	
	outputLatencies at: aSequence put: OrderedCollection new.
]

{ #category : #accessing }
SeqMultiExecutor >> registerCompleted: aSequence on: aFrame at: aTimePoint [
	| startPoint lastPoint |
	completedFrames at: aSequence update: [:n | n + 1].
	startPoint := (starts at: aSequence) removeKey: aFrame.
	(latencies at: aSequence) add: (aTimePoint - startPoint).
	
	lastPoint := lastOutputs at: aSequence ifAbsent: [ 0 asDuration ].
	(outputLatencies at: aSequence) add: (aTimePoint - lastPoint).
	lastOutputs at: aSequence put: aTimePoint.
]

{ #category : #accessing }
SeqMultiExecutor >> registerDropped: aSequence [
	droppedFrames at: aSequence update: [ :x | x + 1 ] initial: [ 1 ].
]

{ #category : #accessing }
SeqMultiExecutor >> registerStarted: aSequence on: aFrame at: aTimePoint [
	starts at: aSequence at: aFrame put: aTimePoint.
]
