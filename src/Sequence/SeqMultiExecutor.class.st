Class {
	#name : #SeqMultiExecutor,
	#superclass : #SeqExecutor,
	#instVars : [
		'elapsed',
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
	| counters dropped |
	counters := super counters: aSequence.
	dropped := droppedFrames at: aSequence ifAbsent: [0].
	counters at: #droppedFrames put: dropped.
	^counters

]

{ #category : #accessing }
SeqMultiExecutor >> initialize [
	super initialize.

	droppedFrames := Dictionary new.
	elapsed := 0 ms.
]

{ #category : #accessing }
SeqMultiExecutor >> registerDropped: aSequence [
	droppedFrames at: aSequence update: [ :x | x + 1 ] initial: [ 1 ].
]
