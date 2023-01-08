Class {
	#name : #SeqFrame,
	#superclass : #Object,
	#instVars : [
		'id',
		'timestamp',
		'data',
		'sequence',
		'availableSince',
		'dropped'
	],
	#category : #Sequence
}

{ #category : #accessing }
SeqFrame >> availableSince [
	^ availableSince
]

{ #category : #'as yet unclassified' }
SeqFrame >> availableSince: aTimePoint [
	availableSince := aTimePoint.
]

{ #category : #accessing }
SeqFrame >> data [
	^ data
]

{ #category : #accessing }
SeqFrame >> data: anObject [
	data := anObject
]

{ #category : #'as yet unclassified' }
SeqFrame >> dropped [
	^dropped
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
SeqFrame >> initialize [
	super initialize.
	dropped := false. "Assume SeqFrame must be marked explicitly to be dropped."
]

{ #category : #'as yet unclassified' }
SeqFrame >> markDropped [
	dropped := true
]

{ #category : #accessing }
SeqFrame >> printOn: aStream [
	aStream 
		nextPutAll: 'SeqFrame:'.
	id printOn: aStream
]

{ #category : #attributes }
SeqFrame >> sequence [
	^ sequence
]

{ #category : #accessing }
SeqFrame >> sequence: anObject [
	sequence := anObject
]

{ #category : #accessing }
SeqFrame >> timestamp [
	^ timestamp
]

{ #category : #accessing }
SeqFrame >> timestamp: anObject [
	timestamp := anObject
]
