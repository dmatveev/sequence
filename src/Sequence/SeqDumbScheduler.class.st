Class {
	#name : #SeqDumbScheduler,
	#superclass : #SeqScheduler,
	#category : #Sequence
}

{ #category : #'as yet unclassified' }
SeqDumbScheduler >> decide: aCollectionOfStreams [
	^aCollectionOfStreams first
]
