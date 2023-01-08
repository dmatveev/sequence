"
This class captures various information on Sequences to execute for SeqMultiExecutor.

Introduced mainly to avoid the API mess.
"
Class {
	#name : #SeqExecOptions,
	#superclass : #Object,
	#instVars : [
		'priority',
		'inputGenerator',
		'inputStream',
		'allowFrameDrop',
		'sequence'
	],
	#category : #Sequence
}

{ #category : #'as yet unclassified' }
SeqExecOptions >> dropFrames [
	"FIXME: Probably this is not the best semantic for this method..
	One can confuse it with a getter."
	allowFrameDrop := true.
]

{ #category : #'as yet unclassified' }
SeqExecOptions >> hasFrameDropAllowed [
	^allowFrameDrop
]

{ #category : #'as yet unclassified' }
SeqExecOptions >> initialize [
	super initialize.
	allowFrameDrop := false.
	priority := 0.
]

{ #category : #accessing }
SeqExecOptions >> inputStream [

	^ inputStream ifNil: [ 
		"TODO: This is a huge abstraction leak here: a sequence is required for input Stream!"
		inputStream := (SeqFrameSource using: [] for: sequence) ]
]

{ #category : #accessing }
SeqExecOptions >> inputStream: anObject [

	inputStream := anObject
]

{ #category : #accessing }
SeqExecOptions >> priority [

	^ priority
]

{ #category : #accessing }
SeqExecOptions >> priority: anObject [

	priority := anObject
]

{ #category : #'as yet unclassified' }
SeqExecOptions >> sequence: aSequence [ 
	"TODO: This is a huge abstraction leak here: a sequence is required for input Stream!"
	sequence := aSequence
]
