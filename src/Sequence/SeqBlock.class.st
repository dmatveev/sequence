Class {
	#name : #SeqBlock,
	#superclass : #Object,
	#instVars : [
		'name',
		'duration',
		'consumers',
		'producers'
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

{ #category : #accessors }
SeqBlock >> consumers [
	^ consumers
]

{ #category : #'accessing-testing' }
SeqBlock >> consumes: aSeqBlock [
	^producers includes: aSeqBlock
]

{ #category : #accessors }
SeqBlock >> initialize [
	consumers := Set new.
	producers := Set new.
]

{ #category : #accessors }
SeqBlock >> latency: aSeqDuration [ 
	duration := aSeqDuration 
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

{ #category : #'accessing-testing' }
SeqBlock >> produces: aSeqBlock [
	^self consumers includes: aSeqBlock
]