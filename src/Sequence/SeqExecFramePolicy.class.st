Class {
	#name : #SeqExecFramePolicy,
	#superclass : #Object,
	#instVars : [
		'sequence'
	],
	#category : #Sequence
}

{ #category : #testing }
SeqExecFramePolicy >> handleStart: blockStream exec: aSeqExecutor pending: pendingFrames [

	self subclassResponsibility
]

{ #category : #testing }
SeqExecFramePolicy >> sequence: aSequence [
	sequence := aSequence
]
