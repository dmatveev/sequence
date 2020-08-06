Class {
	#name : #SeqAllocContinuous,
	#superclass : #SeqAllocPolicy,
	#category : #Sequence
}

{ #category : #accessing }
SeqAllocContinuous class >> tag [
	^ #continuous
]

{ #category : #scheduling }
SeqAllocContinuous >> selectLanes: aCollection for: aNumber [
	"Lookup for a continuous range of lanes of the given number"
	| group |
	group := (aCollection groupByRuns: [ :each | each isLocked ])
		detect: [ :g | (g size >= aNumber) and: [g allSatisfy: [:each | each isLocked not]]]
		ifNone: [ ^#() ].
	^group copyFrom: 1 to: aNumber.
]
