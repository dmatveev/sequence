Class {
	#name : #SeqExecutor,
	#superclass : #Object,
	#instVars : [
		'completedFrames',
		'lastOutputs',
		'latencies',
		'outputLatencies',
		'starts'
	],
	#category : #Sequence
}

{ #category : #accessing }
SeqExecutor >> counters: aSequence [
	| counters frames |

	"Generate execution counters based on what we've registered"
	counters := Dictionary new.
	frames := completedFrames at: aSequence ifAbsent: [0].
	counters at: #latencyAverage put: (frames > 0 ifTrue: [(latencies at: aSequence) average] ifFalse: [0 ms]).
	counters at: #latencyMedian  put: (frames > 0 ifTrue: [(latencies at: aSequence) median]  ifFalse: [0 ms]).
	counters at: #latencyMax     put: (frames > 0 ifTrue: [(latencies at: aSequence) max]     ifFalse: [0 ms]).
	counters at: #outputAverage  put: (frames > 0 ifTrue: [(outputLatencies at: aSequence) average] ifFalse: [ 0 ms ]).
	counters at: #outputMedian   put: (frames > 0 ifTrue: [(outputLatencies at: aSequence) median]  ifFalse: [ 0 ms ]).
	counters at: #outputMax      put: (frames > 0 ifTrue: [(outputLatencies at: aSequence) max]     ifFalse: [ 0 ms ]).
	counters at: #completedFrames put: frames.
	^counters
]

{ #category : #accessing }
SeqExecutor >> initialize [
	super initialize.
	completedFrames := Dictionary new.
	latencies := Dictionary new.
	starts := Dictionary new.
	outputLatencies := Dictionary new.
	lastOutputs := Dictionary new.
	"FIXME: Too much counters. Maybe can replaced with a counters structure
	and a single Dictionary (Sequence -> Counters)"
]

{ #category : #accessing }
SeqExecutor >> register: aSequence [
	latencies at: aSequence put: OrderedCollection new.
	starts at: aSequence put: Dictionary new.
	
	outputLatencies at: aSequence put: OrderedCollection new.
]

{ #category : #accessing }
SeqExecutor >> registerCompleted: aSequence on: aFrame at: aTimePoint [
	| startPoint lastPoint |
	completedFrames at: aSequence update: [:n | n + 1] initial: [ 1 ].
	startPoint := (starts at: aSequence) removeKey: aFrame.
	(latencies at: aSequence) add: (aTimePoint - startPoint).
	
	lastPoint := lastOutputs at: aSequence ifAbsent: [ 0 asDuration ].
	(outputLatencies at: aSequence) add: (aTimePoint - lastPoint).
	lastOutputs at: aSequence put: aTimePoint.
]

{ #category : #accessing }
SeqExecutor >> registerStarted: aSequence on: aFrame at: aTimePoint [
	starts at: aSequence at: aFrame put: aTimePoint.
]

{ #category : #accessing }
SeqExecutor >> runFor: aDuration [
	self subclassResponsibility 
]
