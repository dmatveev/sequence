Class {
	#name : #SeqAllocPolicy,
	#superclass : #Object,
	#classVars : [
		'policies'
	],
	#category : #Sequence
}

{ #category : #accessing }
SeqAllocPolicy class >> at: aSymbol [
	policies ifNil: [ policies := Dictionary new. ].
	^policies
		at: aSymbol
		ifAbsentPut: [| cls |
			cls := self subclasses detect: [ :each | each tag == aSymbol ].
			cls new]
]

{ #category : #'as yet unclassified' }
SeqAllocPolicy >> selectLanes: aCollection for: aNumber [
	self subclassResponsibility
]
