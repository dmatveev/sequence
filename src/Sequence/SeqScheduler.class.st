Class {
	#name : #SeqScheduler,
	#superclass : #Object,
	#category : #Sequence
}

{ #category : #'as yet unclassified' }
SeqScheduler >> askLockOn: aSeqTarget for: aSeqEventStream at: aSeqBlock [ 
	"Say YES in the default implementation"
	^true
]

{ #category : #'as yet unclassified' }
SeqScheduler >> decide: aCollectionOfStreams [
	self subclassResponsibility
]

{ #category : #'as yet unclassified' }
SeqScheduler >> waitlist: aSeqEventStream to: aSeqTarget [ 
	"Do nothing by default."
]
