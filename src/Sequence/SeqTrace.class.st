Class {
	#name : #SeqTrace,
	#superclass : #Object,
	#instVars : [
		'targets',
		'numFrames',
		'allLanes',
		'colors',
		'sequence'
	],
	#category : #Sequence
}

{ #category : #'instance creation' }
SeqTrace class >> on: aSequence [
	^self new
		sequence: aSequence;
		yourself
]

{ #category : #rendering }
SeqTrace >> addLegend: view [ 
	| lb percent |
	percent := [ :u | (100 * u) round: 2 ].
	lb := RSLegend new container: view.
	lb
		beFixedWithTitle: 'Statistics'.
	lb
		text: 'Throughput: ', (self throughput round: 2) asString, ' FPS';
		text: 'Utilization: ', (percent value: self utilization) asString, '%'.
	lb	build.
]

{ #category : #accessors }
SeqTrace >> allEvents [
	| s |
	"TODO: This operation may be costly so probably worth caching"
	s := Set new.
	(targets collect: #execLanes) flattened do: [:each | s addAll: each events]. 
	^s
]

{ #category : #accessors }
SeqTrace >> allLanes [
	"This object needs to be cached to preserve the order in-between calls"
	^allLanes ifNil: [ | knownTargets topoTargets w |
		knownTargets := Set new.
		topoTargets := sequence topoSorted collect: #target.
		w := WriteStream on: OrderedCollection new.
		topoTargets
			reject: [:each | knownTargets includes: each]
			thenDo: [:each | knownTargets add: each.
								  w nextPutAll: each execLanes].
		allLanes := w contents ]
]

{ #category : #rendering }
SeqTrace >> colorFor: anEvent [
	| index |
	"Pick an event color from a palette given the
	block's topological index"
	index := sequence topoSorted indexOf: anEvent seqBlock.
	^self colors scale: index
]

{ #category : #rendering }
SeqTrace >> colors [
	^colors ifNil: [
		colors := (RSColorPalette qualitative accent8) ]
]

{ #category : #'GTInspector-Extensions' }
SeqTrace >> inspectorCanvas [
	<inspectorPresentationOrder: 90 title: 'Canvas'>
	| canvas |
	canvas := RSCanvas new.
	self renderOn: canvas.
	^ SpRoassal3InspectorPresenter new
		canvas: canvas;
		yourself
]

{ #category : #rendering }
SeqTrace >> laneHeight [
	^32
]

{ #category : #modelling }
SeqTrace >> numFrames [
	"TODO: Can this be calculated?"
	^numFrames
]

{ #category : #accessing }
SeqTrace >> numFrames: anObject [
	numFrames := anObject
]

{ #category : #rendering }
SeqTrace >> positionFor: anEvent [
	| x y |
	x := (anEvent startTime asMicroseconds / 1000) asFloat.
	y := self laneHeight * (self allLanes indexOf: anEvent lane).
	"Those are the top-left coordinates, but Roassal seem to expect a central point.."
	^(x @ y) translateBy: ((self widthFor: anEvent)/2) @ 0
]

{ #category : #rendering }
SeqTrace >> renderOn: view [ 
	| es |
	es := self allEvents collect: [ :ev | RSBox new
		width: (self widthFor: ev);
		height: self laneHeight;
		color: (self colorFor: ev);
		borderColor: Color veryDarkGray;
		model: ev	].
	es do: [ :each | each translateTo: (self positionFor: each model) ].
	view addAll: es.
	self addLegend: view.
	view @ RSCanvasController.
]

{ #category : #accessors }
SeqTrace >> sequence: aSequence [
	sequence := aSequence.
	targets := sequence targets.
	allLanes := nil. "Invalidate the cache"
]

{ #category : #modelling }
SeqTrace >> throughput [
	"Estimate throughput based on number of completed frames & time spent:
	walk though all target's execution lanes, pick the last completed time,
	then do some simple math..."
	| lastEvents lastTime |
	lastEvents := self allLanes
		collect: [ :each |
			each events reverse
				detect: [ :ev | ev frame id == (numFrames - 1) ]
				ifNone: [nil] ]
		thenSelect: #isNotNil. "When there are multiple lanes per target, last even can be only in one of them"
	lastTime := (lastEvents maxValue: [ :each | each endTime ]).
	^ (numFrames / (lastTime asMicroseconds / 1e6)) asFloat
]

{ #category : #rendering }
SeqTrace >> utilization [
	^ (allLanes collect: #utilization) average asFloat
]

{ #category : #rendering }
SeqTrace >> widthFor: anEvent [
	^(anEvent duration asMicroseconds / 1000) asFloat
]
