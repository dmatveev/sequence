Class {
	#name : #SeqBlock,
	#superclass : #Object,
	#instVars : [
		'name',
		'duration',
		'consumers',
		'producers',
		'target',
		'allocPolicy',
		'lanes',
		'taskBlock'
	],
	#category : #Sequence
}

{ #category : #'instance creation' }
SeqBlock class >> named: aString [ 
	^self new
		name: aString;
		yourself
]

{ #category : #'sequence flow' }
SeqBlock >> >> aSeqBlock [ 
	(aSeqBlock == self) ifTrue: [ SeqCycleException signal ].
	
	consumers add: aSeqBlock.
	
	"Let aSeqBlock know that self is its producer"
	aSeqBlock addProducer: self.
	
	"Make aSeqBlock return value to enable chaining"
	^aSeqBlock
]

{ #category : #'accessing - private' }
SeqBlock >> addProducer: aSeqBlock [
	(aSeqBlock == self) ifTrue: [ SeqCycleException signal ].

	producers add: aSeqBlock
]

{ #category : #accessing }
SeqBlock >> allocPolicy [
	^allocPolicy
]

{ #category : #accessors }
SeqBlock >> allocPolicy: aSymbol [
	allocPolicy := aSymbol
]

{ #category : #accessors }
SeqBlock >> consumers [
	^ consumers
]

{ #category : #'accessing-testing' }
SeqBlock >> consumes: aSeqBlock [
	^producers includes: aSeqBlock
]

{ #category : #accessors }
SeqBlock >> duration [
	^ duration
]

{ #category : #accessors }
SeqBlock >> initialize [
	super initialize.
	consumers := Set new.
	producers := Set new.
	allocPolicy := #sparse.
	lanes := 1.
	taskBlock := [ :frame | 1 ].
]

{ #category : #accessors }
SeqBlock >> lanes [
	^lanes
]

{ #category : #accessors }
SeqBlock >> lanes: aNumber [
	lanes := aNumber
]

{ #category : #accessors }
SeqBlock >> latency: aSeqDuration [ 
	duration := aSeqDuration 
]

{ #category : #accessors }
SeqBlock >> name [
	^ name
]

{ #category : #accessing }
SeqBlock >> name: aString [ 
	name := aString
]

{ #category : #printing }
SeqBlock >> printOn: aStream [
	aStream 
		nextPutAll: 'SeqBlock:';
		nextPutAll: name
]

{ #category : #accessors }
SeqBlock >> producers [
	^ producers
]

{ #category : #'accessing-testing' }
SeqBlock >> produces: aSeqBlock [
	^self consumers includes: aSeqBlock
]

{ #category : #accessors }
SeqBlock >> target [
	^target ifNil: [ target := SeqTarget new ]
]

{ #category : #accessors }
SeqBlock >> target: aSeqTarget [ 
	target := aSeqTarget
]

{ #category : #tasks }
SeqBlock >> tasks [
	^taskBlock
]

{ #category : #accessors }
SeqBlock >> tasks: aBlockClosure [ 
	taskBlock := aBlockClosure
]
