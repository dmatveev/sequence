Class {
	#name : #SeqTrace,
	#superclass : #Object,
	#instVars : [
		'targets'
	],
	#category : #Sequence
}

{ #category : #'GTInspector-Extensions' }
SeqTrace >> gtInspectorPreviewIn: composite [
	<gtInspectorPresentationOrder: 0>
	^ composite roassal2
		title: 'View';
		painting: [ :view | self renderOn: view ]
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
