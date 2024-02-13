Class {
	#name : #SeqLaneMock,
	#superclass : #Object,
	#instVars : [
		'locked'
	],
	#category : #'Sequence-Tests-Targets'
}

{ #category : #accessing }
SeqLaneMock >> isLocked [
	^locked
]

{ #category : #accessing }
SeqLaneMock >> locked: aBoolean [
	locked := aBoolean
]
