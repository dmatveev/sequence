Class {
	#name : #SeqTrace,
	#superclass : #Object,
	#instVars : [
		'targets',
		'numFrames'
	],
	#category : #Sequence
}

{ #category : #'as yet unclassified' }
SeqTrace class >> numFrames: anInteger [ 
	self shouldBeImplemented.
]

{ #category : #'instance creation' }
SeqTrace class >> on: targets [
	^self new
		targets: targets;
		yourself
]

{ #category : #'GTInspector-Extensions' }
SeqTrace >> gtInspectorPreviewIn: composite [
	<gtInspectorPresentationOrder: 0>
	^ composite roassal2
		title: 'View';
		painting: [ :view | self renderOn: view ]
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
SeqTrace >> renderOn: view [ 
	"Draw lanes for execution targets"
	| es i |
	es := (RTBox new width: 100; height: 8) elementsOn: targets.
	i := 0.
	es do: [ :each | each translateTo: 0 @ (i*10). i := i+1 ].
	view addAll: es.
]

{ #category : #accessors }
SeqTrace >> targets [
	^ targets
]

{ #category : #accessors }
SeqTrace >> targets: aCollection [ 
	targets := aCollection
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
