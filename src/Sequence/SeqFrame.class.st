Class {
	#name : #SeqFrame,
	#superclass : #Object,
	#instVars : [
		'id',
		'timestamp',
		'data'
	],
	#category : #Sequence
}

{ #category : #accessing }
SeqFrame >> data [
	^ data
]

{ #category : #accessing }
SeqFrame >> data: anObject [
	data := anObject
]

{ #category : #accessing }
SeqFrame >> id [
	^ id
]

{ #category : #accessing }
SeqFrame >> id: anObject [
	id := anObject
]

{ #category : #accessing }
SeqFrame >> printOn: aStream [
	aStream 
		nextPutAll: 'SeqFrame:'.
	id printOn: aStream
]

{ #category : #accessing }
SeqFrame >> timestamp [
	^ timestamp
]

{ #category : #accessing }
SeqFrame >> timestamp: anObject [
	timestamp := anObject
]
