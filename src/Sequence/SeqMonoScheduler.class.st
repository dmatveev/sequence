Class {
	#name : #SeqMonoScheduler,
	#superclass : #SeqScheduler,
	#instVars : [
		'input',
		'sequence'
	],
	#category : #Sequence
}

{ #category : #accessing }
SeqMonoScheduler >> completedFrames [
	self subclassResponsibility 
]

{ #category : #accessing }
SeqMonoScheduler >> input [
	^ input
]

{ #category : #accessors }
SeqMonoScheduler >> input: aSeqFrameSource [ 
	input := aSeqFrameSource
]

{ #category : #accessing }
SeqMonoScheduler >> sequence [
	^ sequence
]

{ #category : #accessing }
SeqMonoScheduler >> sequence: anObject [
	sequence := anObject
]
