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
		'topoSorted',
		'targets'
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

{ #category : #private }
Sequence >> gtInspectorPreviewIn: composite [
	<gtInspectorPresentationOrder: 0>
	^ composite roassal2
		title: 'View';
		painting: [ :view | self renderOn: view ]
]

{ #category : #testing }
Sequence >> includes: aSeqBlock [ 
	^allSeqBlocks includes: aSeqBlock
]

{ #category : #'accessing - private' }
Sequence >> inspectorCanvas [
	<inspectorPresentationOrder: 90 title: 'Canvas'>
	| canvas |
	canvas := RSCanvas new.
	self renderOn: canvas.
	^ SpRoassal3InspectorPresenter new
		canvas: canvas;
		yourself
]

{ #category : #rendering }
Sequence >> renderOn: view [
	| labels eb |
	labels := allSeqBlocks collect: [:seqBlock || label box |
		label := RSLabel new 
			text: seqBlock name;
			color: Color black.
		box := RSBox new
			withBorder;
			color: Color lightGreen;
			extent: label extent + 10.
		RSComposite new
			draggable;
			model: seqBlock;
			shapes: (RSGroup with: box with: label);
			yourself].
	view addAll: labels.
	
	"Apply tree layout"
	eb := RSLineBuilder orthoHorizontal
		markerEnd: (RSMarker new 
			offset: 2;
			shape: (RSShapeFactory triangle 
				color: Color black;
				size: 5;
				yourself));
		attachPoint: RSHorizontalAttachPoint new; 
		canvas: view;
		shapes: view nodes;
		connectToAll: #consumers.
	RSHorizontalDominanceTreeLayout new on: view nodes.
	view @ RSCanvasController 
]

{ #category : #model }
Sequence >> runFor: aDuration using: aSchedulerClass [
	^self
		runFor: aDuration
		using: aSchedulerClass 
		on: (SeqDataStream block: []).
]

{ #category : #model }
Sequence >> runFor: aDuration using: aSchedulerClass on: aDataStreamOrBlock [
	|  scheduler stream |
	stream := aDataStreamOrBlock isBlock
		ifTrue: [ SeqDataStream block: aDataStreamOrBlock ]
		ifFalse: [ aDataStreamOrBlock ].
	scheduler := aSchedulerClass new
		sequence: self;
		input: (SeqFrameSource on: stream);
		yourself.
	scheduler runFor: aDuration.
	^(SeqTrace on: self)
		numFrames: scheduler completedFrames;
		yourself
]

{ #category : #'accessing - private' }
Sequence >> setStart: aCollection [ 
	seqHead := aCollection
]

{ #category : #private }
Sequence >> tails [
	^seqTail
]

{ #category : #accessors }
Sequence >> targets [
	^targets ifNil: [ 
		targets := ((allSeqBlocks) collect: #target) asSet ]
]

{ #category : #model }
Sequence >> tasksFor: aFrame [
	| stream |
	
	"Unroll the execution flow to a graph for this specific frame.
	TODO: So far it is topologically sorted list with no extra dependency information
	TODO: It also can be optimized if blocks don't really depends on the run-time information"
	stream := WriteStream on: OrderedCollection new.
	self topoSorted do: [ :each |
		each doJob: aFrame.
		(each tasks value: aFrame) timesRepeat: [ stream nextPut: each ]].
	^stream contents
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

{ #category : #accessors }
Sequence >> topoSorted [
	^ topoSorted
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
