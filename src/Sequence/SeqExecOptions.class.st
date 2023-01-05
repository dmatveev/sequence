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
		'allowFrameDrop'
	],
	#category : #Sequence
}

{ #category : #accessing }
SeqExecOptions >> inputStream [

	^ inputStream
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
