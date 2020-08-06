Class {
	#name : #SeqTrace,
	#superclass : #Object,
	#category : #Sequence
}

{ #category : #'GTInspector-Extensions' }
SeqTrace >> gtInspectorPreviewIn: composite [
	<gtInspectorPresentationOrder: 0>
	^ composite roassal2
		title: 'View';
		painting: [ :view |  ]
]
