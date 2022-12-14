Class {
	#name : #SeqEventStreamMock,
	#superclass : #Object,
	#instVars : [
		'nextTick'
	],
	#category : #'Sequence-Tests'
}

{ #category : #accessing }
SeqEventStreamMock >> nextTick [

	^ nextTick
]

{ #category : #accessing }
SeqEventStreamMock >> nextTick: anObject [

	nextTick := anObject
]
