Class {
	#name : #SeqMultiScheduler,
	#superclass : #SeqScheduler,
	#instVars : [
		'elapsed',
		'completedFrames'
	],
	#category : #Sequence
}

{ #category : #accessing }
SeqMultiScheduler >> add: aSequence [
	self add: aSequence with: [ ]

]

{ #category : #accessing }
SeqMultiScheduler >> add: aSequence with: anInputStreamBlock [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SeqMultiScheduler >> completedFrames: aSequence [
	^completedFrames at: aSequence
]

{ #category : #accessing }
SeqMultiScheduler >> initialize [
	super initialize.
	completedFrames := Dictionary new.
	elapsed := 0 ms.
]

{ #category : #accessing }
SeqMultiScheduler >> registerCompleted: aSequence [
	completedFrames at: aSequence update: [:n | n + 1].

]
