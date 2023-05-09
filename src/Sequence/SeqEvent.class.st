Class {
	#name : #SeqEvent,
	#superclass : #Object,
	#instVars : [
		'startTime',
		'block',
		'frame',
		'lane',
		'duration'
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
SeqEvent >> duration [
	^duration
]

{ #category : #accessing }
SeqEvent >> duration: aDuration [
	duration := aDuration
]

{ #category : #modelling }
SeqEvent >> endTime [
	^startTime + self duration
]

{ #category : #accessing }
SeqEvent >> frame [
	^ frame
]

{ #category : #accessing }
SeqEvent >> frame: anObject [
	frame := anObject
]

{ #category : #accessing }
SeqEvent >> lane [
	^ lane
]

{ #category : #accessing }
SeqEvent >> lane: anObject [
	lane := anObject
]

{ #category : #accessing }
SeqEvent >> printOn: aStream [
	startTime printOn: aStream.
	aStream
		nextPutAll: ' - ';
		nextPutAll: block name;
	   nextPutAll: ' #'.
	frame id printOn: aStream.
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
