Class {
	#name : #SeqUnreachedEnds,
	#superclass : #Error,
	#instVars : [
		'ends'
	],
	#category : #Sequence
}

{ #category : #exceptioninstantiator }
SeqUnreachedEnds class >> signal: aCollectionWithUnreachedEnds [
	^self new
		unreached: aCollectionWithUnreachedEnds;
		signal
]

{ #category : #'as yet unclassified' }
SeqUnreachedEnds >> unreached: aCollection [
	ends := aCollection
]
