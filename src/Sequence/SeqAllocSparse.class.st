Class {
	#name : #SeqAllocSparse,
	#superclass : #SeqAllocPolicy,
	#category : #Sequence
}

{ #category : #accessing }
SeqAllocSparse class >> tag [
	^#sparse
]

{ #category : #'as yet unclassified' }
SeqAllocSparse >> selectLanes: aCollection for: aNumber [
	"Just pick up N free lanes, if any"
	| free |
	free := (aCollection reject: #isLocked).
	(free size < aNumber) ifTrue: [^#()].
	^free copyFrom: 1 to: aNumber.
]
