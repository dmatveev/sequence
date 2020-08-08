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
	^allLanes ifNil: [ | w topoTargets |
		w := WriteStream on: OrderedCollection new.
		topoTargets := sequence topoSorted collect: #target.
		topoTargets do: [ :each | w nextPutAll: each execLanes ].
		allLanes := w contents ]
]

{ #category : #rendering }
SeqTrace >> colorFor: anEvent [
	| index |
	"Pick an event color from a palette given the
	block's topological index"
	index := sequence topoSorted indexOf: anEvent seqBlock.
	^self colors at: index.
]

{ #category : #rendering }
SeqTrace >> colors [
	^colors ifNil: [
		colors := (RTColorPalette qualitative colors: 8 scheme: 'Set2') ]
]

{ #category : #'GTInspector-Extensions' }
SeqTrace >> gtInspectorPreviewIn: composite [
	<gtInspectorPresentationOrder: 0>
	^ composite roassal2
		title: 'View';
		painting: [ :view | self renderOn: view ]
]

{ #category : #rendering }
SeqTrace >> laneHeight [
	^30
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
	| box es |
	box := RTBox new
		width: [:x | self widthFor: x];
		height: self laneHeight;
		color: [ :x | self colorFor: x ].
	es := box elementsOn: self allEvents.
	es do: [ :each | each translateTo: (self positionFor: each model) ].
	view addAll: es.
	view @ RTDoubleScrollBar.
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
	lastEvents := (targets collect: #execLanes) flattened collect: [ :each |
		each events detect: [ :ev | ev frame == (numFrames - 1) ]].
	lastTime := (lastEvents maxFor: [ :each | each endTime ]) endTime.
	^ (numFrames / (lastTime asMicroseconds / 1e6)) asFloat
]

{ #category : #rendering }
SeqTrace >> widthFor: anEvent [
	^(anEvent duration asMicroseconds / 1000) asFloat
]
