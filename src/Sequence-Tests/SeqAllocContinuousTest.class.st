Class {
	#name : #SeqAllocContinuousTest,
	#superclass : #TestCase,
	#instVars : [
		'policy'
	],
	#category : #'Sequence-Tests'
}

{ #category : #running }
SeqAllocContinuousTest >> setUp [
	super setUp.
	policy := SeqAllocPolicy at: #continuous.
]

{ #category : #running }
SeqAllocContinuousTest >> testSelectLanesFor [
	"lanes1 is fully free, so policy should give as us much as we request"
	| lanes |
	lanes := #(0 0 0 0) asSeqLaneMocks.
	self
		assert: (policy selectLanes: lanes for: 2)
		equals: { lanes first. lanes second }.
	self
		assert: (policy selectLanes: lanes for: 3)
		equals: { lanes first. lanes second. lanes third }.
]

{ #category : #running }
SeqAllocContinuousTest >> testSelectLanesFor2 [
	| lanes |
	lanes := #(0 1 0 0) asSeqLaneMocks.
	self
		assert: (policy selectLanes: lanes for: 2)
		equals: { lanes third. lanes fourth. }.
	self
		assert: (policy selectLanes: lanes for: 1)
		equals: { lanes first. }.
	self
		assert: (policy selectLanes: lanes for: 3)
		equals: #().
]

{ #category : #running }
SeqAllocContinuousTest >> testSelectLanesFor3 [
	| lanes |
	lanes := #(1 1 1 0) asSeqLaneMocks.
	self
		assert: (policy selectLanes: lanes for: 2)
		equals: #().
	self
		assert: (policy selectLanes: lanes for: 3)
		equals: #().
	self
		assert: (policy selectLanes: lanes for: 1)
		equals: { lanes fourth }.
]

{ #category : #running }
SeqAllocContinuousTest >> testSelectLanesFor4 [
	| lanes |
	lanes := #(0 0 0 1 0 0 0 0) asSeqLaneMocks.
	self
		assert: (policy selectLanes: lanes for: 4)
		equals: (lanes copyFrom: 5 to: 8).
]
