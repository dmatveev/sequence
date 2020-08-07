Class {
	#name : #SeqEvent,
	#superclass : #Object,
	#instVars : [
		'startTime',
		'block',
		'frame'
	],
	#category : #Sequence
}

{ #category : #'as yet unclassified' }
SeqEvent class >> on: aTimeD with: aBlock inContextOf: aFrame [
	^self new
		startTime: aTimeD;
		block: aBlock;
		frame: aFrame;
		yourself
]

{ #category : #accessing }
SeqEvent >> block [
	^ block
]

{ #category : #accessing }
SeqEvent >> block: anObject [
	block := anObject
]

{ #category : #modelling }
SeqEvent >> endTime [
	^startTime + block duration
]

{ #category : #accessing }
SeqEvent >> frame [
	^ frame
]

{ #category : #accessing }
SeqEvent >> frame: anObject [
	frame := anObject
]

{ #category : #accessors }
SeqEvent >> seqBlock [
	^block
]

{ #category : #accessing }
SeqEvent >> startTime [
	^ startTime
]

{ #category : #accessing }
SeqEvent >> startTime: anObject [
	startTime := anObject
]
