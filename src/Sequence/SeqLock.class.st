Class {
	#name : #SeqLock,
	#superclass : #Object,
	#instVars : [
		'seqBlock'
	],
	#category : #Sequence
}

{ #category : #'instance creation' }
SeqLock class >> with: aSeqBlock [ 
	^self new
		seqBlock: aSeqBlock;
		yourself
]

{ #category : #accessors }
SeqLock >> seqBlock [
	^ seqBlock
]

{ #category : #accessors }
SeqLock >> seqBlock: aSeqBlock [ 
	seqBlock := aSeqBlock
]
