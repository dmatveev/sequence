Class {
	#name : #SeqScene,
	#superclass : #Object,
	#instVars : [
		'seqHead',
		'allSeqBlocks',
		'seqTail'
	],
	#category : #Sequence
}

{ #category : #'instance creation' }
SeqScene class >> startingWith: aSeqBlock [ 
	^self new
		setStart: {aSeqBlock.};
		traceDown;
		yourself
]

{ #category : #private }
SeqScene >> checkCycle: nextBlock path: aSet [
	(aSet includes: nextBlock) ifTrue: [ SeqCycleException signal ].
	seqTail ifNotNil: [(seqTail includes: nextBlock) ifTrue: [ ^self ]].
	aSet add: nextBlock.
	nextBlock consumers do: [ :each | 
		self checkCycle: each path: aSet ].
	aSet remove: nextBlock.
]

{ #category : #private }
SeqScene >> checkCycles [
	seqHead do: [ :head |
		"Recursively check if this pipeline has no cycles."
		self checkCycle: head path: Set new.
	]
]

{ #category : #testing }
SeqScene >> includes: aSeqBlock [ 
	^allSeqBlocks includes: aSeqBlock
]

{ #category : #model }
SeqScene >> runFor: aDuration [
	| trace |
	trace := SeqTrace new.
	trace targets: (allSeqBlocks collect: #target) asSet.
	^trace
]

{ #category : #'accessing - private' }
SeqScene >> setStart: aCollection [ 
	seqHead := aCollection
]

{ #category : #private }
SeqScene >> traceDown [
	"Build the internal metric for this pipeline.
	Implementation TBD"
	self checkCycles.
	self unroll.
]

{ #category : #private }
SeqScene >> unroll [
	| stack |
	allSeqBlocks := Set new. "TODO: Ordered collection instead?"
	stack := Stack withAll: seqHead.
	[stack isEmpty] whileFalse: [ | this | 
		"Recursively add seq blocks following the prod-cons relationship, starting with head"
		this := stack pop.
		"Sometimes a block may be visited more than once (e.g. with two inputs)"
		(allSeqBlocks includes: this) ifFalse: [
			this consumers do: [ :each | stack push: each ].
			allSeqBlocks add: this ]]

]
