Class {
	#name : #SeqEventStreamMock,
	#superclass : #Object,
	#instVars : [
		'nextTick',
		'priority',
		'blockToWork'
	],
	#category : #'Sequence-Tests'
}

{ #category : #mock }
SeqEventStreamMock >> blockToWork [
	^blockToWork
]

{ #category : #mock }
SeqEventStreamMock >> blockToWork: aSeqBlock [
	blockToWork := aSeqBlock
]

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

{ #category : #mock }
SeqEventStreamMock >> wantsToLeave [
	"Required for priority RR scheduler test"
	^false
]
