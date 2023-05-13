Class {
	#name : #SeqMonoExecutor,
	#superclass : #SeqExecutor,
	#instVars : [
		'input',
		'sequence'
	],
	#category : #Sequence
}

{ #category : #accessing }
SeqMonoExecutor >> completedFrames [
	self subclassResponsibility 
]

{ #category : #accessing }
SeqMonoExecutor >> input [
	^ input
]

{ #category : #accessors }
SeqMonoExecutor >> input: aSeqFrameSource [ 
	input := aSeqFrameSource
]

{ #category : #accessing }
SeqMonoExecutor >> sequence [
	^ sequence
]

{ #category : #accessing }
SeqMonoExecutor >> sequence: anObject [
	sequence := anObject.
	self register: anObject
]
