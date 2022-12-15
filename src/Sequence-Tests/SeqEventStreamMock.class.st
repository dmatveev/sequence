Class {
	#name : #SeqEventStreamMock,
	#superclass : #Object,
	#instVars : [
		'nextTick',
		'priority'
	],
	#category : #'Sequence-Tests'
}

{ #category : #mock }
SeqEventStreamMock >> initialize [
	priority := 0
]

{ #category : #accessing }
SeqEventStreamMock >> nextTick [

	^ nextTick
]

{ #category : #accessing }
SeqEventStreamMock >> nextTick: anObject [

	nextTick := anObject
]

{ #category : #mock }
SeqEventStreamMock >> priority [
	^ priority
]

{ #category : #mock }
SeqEventStreamMock >> priority: p [ 
	priority := p.
]
