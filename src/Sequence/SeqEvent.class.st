Class {
	#name : #SeqEvent,
	#superclass : #Object,
	#instVars : [
		'startTime',
		'block'
	],
	#category : #Sequence
}

{ #category : #'as yet unclassified' }
SeqEvent class >> on: aTimeD with: aBlock [
	^self new
		startTime: aTimeD;
		block: aBlock;
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

{ #category : #accessing }
SeqEvent >> startTime [
	^ startTime
]

{ #category : #accessing }
SeqEvent >> startTime: anObject [
	startTime := anObject
]
