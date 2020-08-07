Class {
	#name : #SeqAllocSparseTest,
	#superclass : #TestCase,
	#instVars : [
		'policy'
	],
	#category : #'Sequence-Tests'
}

{ #category : #running }
SeqAllocSparseTest >> setUp [
	super setUp.
	policy := SeqAllocPolicy at: #sparse.
]

{ #category : #running }
SeqAllocSparseTest >> testSelectLanesFor [
	| lanes |
	lanes := #(0 0 0 0) asSeqLaneMocks.
	1 to: 4 do: [ :i | self
		assert: (policy selectLanes: lanes for: i)
		equals: (lanes copyFrom: 1 to: i)]
]

{ #category : #running }
SeqAllocSparseTest >> testSelectLanesFor2 [
	| lanes |
	lanes := #(0 1 0 0) asSeqLaneMocks.
	self
		assert: (policy selectLanes: lanes for: 2)
		equals: { lanes first. lanes third }.
	self
		assert: (policy selectLanes: lanes for: 3)
		equals: { lanes first. lanes third. lanes fourth }.
	self
		assert: (policy selectLanes: lanes for: 4)
		equals: #()
]
