Class {
	#name : #SeqTrace,
	#superclass : #Object,
	#instVars : [
		'targets',
		'allLanes',
		'colors',
		'sequences',
		'counters',
		'laneYs',
		'laneHeights'
	],
	#category : #Sequence
}

{ #category : #'instance creation' }
SeqTrace class >> on: aSequence [
	^self new
		sequence: aSequence;
		yourself
]

{ #category : #accessors }
SeqTrace >> add: aSequence over: sequenceCounters [
	sequences add: aSequence.
	counters at: aSequence put: sequenceCounters.
	targets addAll: aSequence targets.
]

{ #category : #rendering }
SeqTrace >> addLegend: view [ 
	| lb percent |
	percent := [ :u | (100 * u) round: 2 ].
	lb := RSLegend new container: view.
	lb
		beFixedWithTitle: 'Statistics'.
	sequences do: [ :each |
		| cntrs |
		cntrs := counters at: each.
		lb text: (' ' join: {each name. 'average latency:'. (cntrs at: #latencyAverage) asMilliSeconds. 'ms'}).
		lb text: (' ' join: {each name. 'median latency:'.  (cntrs at: #latencyMedian)  asMilliSeconds. 'ms'})].
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
		topoTargets := (sequences collect: [:each | each topoSorted collect: #target]) flattened.
		w := WriteStream on: OrderedCollection new.
		topoTargets
			reject: [:each | knownTargets includes: each]
			thenDo: [:each | knownTargets add: each.
								  w nextPutAll: each execLanes].
		allLanes := w contents ]
]

{ #category : #rendering }
SeqTrace >> colorFor: anEvent [
	| baseColor |
	baseColor := self colors scale: anEvent frame sequence.
	
	"Adjust color transparency pased on index. Sources handled separately"
	"^Color white alphaMixed: (anEvent frame id * 0.05) with: baseColor."
	^baseColor

]

{ #category : #rendering }
SeqTrace >> colors [
	^colors ifNil: [colors := RSColorPalette qualitative set312.
		"This is a trick to ensure the scale for every individual pipeline based on its index.
		(make it more deterministic)"
		sequences do: [ :each | colors scale: each ].
		colors]
]

{ #category : #initialization }
SeqTrace >> initialize [
	super initialize.
	sequences := OrderedCollection new.
	counters := Dictionary new.
	targets := Set new.
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
SeqTrace >> laneHeight: aLane [
	^aLane allLive ifTrue: [6] ifFalse: [24]
]

{ #category : #accessors }
SeqTrace >> laneHeights [
	^ laneHeights ifNil: [
		laneHeights := self allLanes collect: [ :each | self laneHeight: each]]
]

{ #category : #accessors }
SeqTrace >> laneYs [
	^ laneYs ifNil: [ | w thisOffset |
		thisOffset := 0.
		w := WriteStream on: OrderedCollection new.
		self laneHeights do: [ :h |
				w nextPut: thisOffset.
				thisOffset := thisOffset + h ].
		laneYs := w contents	]
]

{ #category : #modelling }
SeqTrace >> numFrames [
	"Aux method. Should be called for Mono case only"
	self assert: sequences size = 1.
	^counters at: sequences first
]

{ #category : #accessing }
SeqTrace >> numFrames: anObject [
	"Aux method. Works only for the mono case"
	self assert: sequences size = 1.
	counters at: sequences first put: anObject.
]

{ #category : #rendering }
SeqTrace >> positionFor: anEvent [
	| x y idx offsetFix |
	idx := self allLanes indexOf: anEvent lane. "This may be a bottleneck"
	x := anEvent startTime asMilliSeconds asFloat.
	y := self laneYs at: idx.

	"Those are the top-left coordinates, but Roassal seem to expect a central point.."
	offsetFix := ((self widthFor: anEvent)/2) @ ((self laneHeights at: idx)/2).
	^(x @ y) translateBy: offsetFix.
]

{ #category : #rendering }
SeqTrace >> renderOn: view [ 
	| es b |
	b := RSBorder new
		color: #veryDarkGray;
		width: 0.5;
		yourself.
	es := self allEvents collect: [ :ev || idx |
		idx := self allLanes indexOf: ev lane.
		RSBox new
			width: (self widthFor: ev);
			height: (self laneHeights at: idx);
			color: (self colorFor: ev);
			border: b;
			model: ev	].
	es do: [ :each | each translateTo: (self positionFor: each model) ].
	view addAll: es.
	self addLegend: view.
	view @ RSCanvasController.
]

{ #category : #accessors }
SeqTrace >> sequence: aSequence [
	"A legacy/compatibility method"
	sequences := Array with: aSequence.
	targets := aSequence targets asSet.
	allLanes := nil. "Invalidate the cache"
]

{ #category : #modelling }
SeqTrace >> throughput [
	"Aux method."
	"Estimate throughput based on number of completed frames & time spent:
	walk though all target's execution lanes, pick the last completed time,
	then do some simple math..."
	| lastEvents lastTime |
	lastEvents := self allLanes
		collect: [ :each |
			each events reverse
				detect: [ :ev | ev frame id == (self numFrames - 1) ]
				ifNone: [nil] ]
		thenSelect: #isNotNil. "When there are multiple lanes per target, last even can be only in one of them"
	lastTime := (lastEvents maxValue: [ :each | each endTime ]).
	^ (self numFrames / (lastTime asMicroseconds / 1e6)) asFloat
]

{ #category : #rendering }
SeqTrace >> utilization [
	^ (allLanes collect: #utilization) average asFloat
]

{ #category : #rendering }
SeqTrace >> widthFor: anEvent [
	^(anEvent duration asMicroseconds / 1000) asFloat
]
