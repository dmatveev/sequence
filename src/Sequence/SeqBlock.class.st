Class {
	#name : #SeqBlock,
	#superclass : #Object,
	#instVars : [
		'name',
		'consumers',
		'producers',
		'target',
		'allocPolicy',
		'lanes',
		'taskBlock',
		'jobBlock',
		'latencyBlock',
		'isLive',
		'streams'
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
SeqBlock >> applyTo: aFrame with: aBlock [
		self doJob: aFrame.
		(self tasks value: aFrame) timesRepeat: aBlock.

]

{ #category : #accessors }
SeqBlock >> consumers [
	^ consumers
]

{ #category : #'accessing-testing' }
SeqBlock >> consumes: aSeqBlock [
	^producers includes: aSeqBlock
]

{ #category : #'accessing-testing' }
SeqBlock >> doJob: aFrame [
	jobBlock value: aFrame 
]

{ #category : #accessors }
SeqBlock >> durationOn: aFrame [
	^ latencyBlock value: aFrame
]

{ #category : #accessors }
SeqBlock >> initialize [
	super initialize.
	consumers := Set new.
	producers := Set new.
	allocPolicy := #sparse.
	lanes := 1.
	taskBlock := [ :frame | 1 ].
	jobBlock := [ :frame | "Do nothing by default" ].
	isLive := false.
]

{ #category : #attributes }
SeqBlock >> isLive [
	^ isLive
]

{ #category : #accessing }
SeqBlock >> job: aBlockClosure [ 
	jobBlock := aBlockClosure
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
SeqBlock >> latency: aSeqDurationOrBlock [
	latencyBlock := aSeqDurationOrBlock isBlock
		ifTrue: [ aSeqDurationOrBlock ]
		ifFalse: [ [ :f | aSeqDurationOrBlock ] ]
]

{ #category : #attributes }
SeqBlock >> live [
	isLive := true.
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

{ #category : #'as yet unclassified' }
SeqBlock >> streams [
	^streams ifNil: [ 1 ]
]

{ #category : #'as yet unclassified' }
SeqBlock >> streams: anInteger [ 
	streams := anInteger
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

{ #category : #tasks }
SeqBlock >> tasks: aBlockClosure [ 
	taskBlock := aBlockClosure
]

{ #category : #simulation }
SeqBlock >> tasksFor: aSeqFrame [ 
	"Returns tasks to execute on the given block during simulation"
	self shouldNotImplement 
]
