Class {
	#name : #SeqAllocPolicyTest,
	#superclass : #TestCase,
	#category : #'Sequence-Tests'
}

{ #category : #tests }
SeqAllocPolicyTest >> testAt [
	| cont sparse |
	cont := SeqAllocPolicy at: #continuous.
	sparse := SeqAllocPolicy at: #sparse.
	self assert: (cont isMemberOf: SeqAllocContinuous).
	self assert: (sparse isMemberOf: SeqAllocSparse).
]
