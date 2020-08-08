"
SeqScene is the main simulation vehicle in the Sequence package.

"
Class {
	#name : #Sequence,
	#superclass : #Object,
	#instVars : [
		'seqHead',
		'allSeqBlocks',
		'seqTail',
		'topoSorted'
	],
	#category : #Sequence
}

{ #category : #'instance creation' }
Sequence class >> startingWith: aSeqBlock [ 
	^self new
		setStart: {aSeqBlock.};
		traceDown;
		yourself
]

{ #category : #private }
Sequence >> checkCycle: nextBlock path: aSet [
	(aSet includes: nextBlock) ifTrue: [ SeqCycleException signal ].
	seqTail ifNotNil: [(seqTail includes: nextBlock) ifTrue: [ ^self ]].
	aSet add: nextBlock.
	nextBlock consumers do: [ :each | 
		self checkCycle: each path: aSet ].
	aSet remove: nextBlock.
]

{ #category : #private }
Sequence >> checkCycles [
	seqHead do: [ :head |
		"Recursively check if this pipeline has no cycles."
		self checkCycle: head path: Set new.
	]
]

{ #category : #testing }
Sequence >> includes: aSeqBlock [ 
	^allSeqBlocks includes: aSeqBlock
]

{ #category : #model }
Sequence >> runFor: aDuration using: aSchedulerClass [
	| targets scheduler |
	targets := (allSeqBlocks collect: #target) asSet.
	scheduler := aSchedulerClass new
		head: seqHead;
		topo: topoSorted;
		targets: targets;
		yourself.
	scheduler runFor: aDuration.
	^(SeqTrace on: targets)
		numFrames: scheduler completedFrames;
		topo: topoSorted;
		yourself
]

{ #category : #'accessing - private' }
Sequence >> seqTopo [
	^topoSorted
]

{ #category : #'accessing - private' }
Sequence >> setStart: aCollection [ 
	seqHead := aCollection
]

{ #category : #private }
Sequence >> tails [
	^seqTail
]

{ #category : #'accessing - private' }
Sequence >> topoSort [
	| visited |
	"Sort the sequence in the topological order"
	visited := Set new.
	topoSorted := OrderedCollection new.
	seqTail do: [ :tail | self topoSort: tail on: topoSorted using: visited ].
]

{ #category : #'accessing - private' }
Sequence >> topoSort: aSeqBlock on: aSortedPath using: aVisitedSet [
	(aVisitedSet includes: aSeqBlock) ifTrue: [ ^self ].
	aVisitedSet add: aSeqBlock.
	aSeqBlock producers do: [ :each |
		self topoSort: each on: aSortedPath using: aVisitedSet ].
	aSortedPath add: aSeqBlock.
]

{ #category : #private }
Sequence >> traceDown [
	"Build the internal metric for this pipeline.
	Implementation TBD"
	self checkCycles.
	self unroll.
	self topoSort.
]

{ #category : #private }
Sequence >> unroll [
	| stack |
	allSeqBlocks := Set new. "TODO: Ordered collection instead?"
	seqTail := Set new.
	stack := Stack withAll: seqHead.
	[stack isEmpty] whileFalse: [ | this | 
		"Recursively add seq blocks following the prod-cons relationship, starting with head"
		this := stack pop.
		"Sometimes a block may be visited more than once (e.g. with two inputs)"
		(allSeqBlocks includes: this) ifFalse: [
			this consumers do: [ :each | stack push: each ].
			this consumers ifEmpty: [ seqTail add: this ].
			allSeqBlocks add: this ]]

]
