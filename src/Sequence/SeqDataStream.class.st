Class {
	#name : #SeqDataStream,
	#superclass : #Object,
	#instVars : [
		'block',
		'now',
		'seq'
	],
	#category : #Sequence
}

{ #category : #'instance creation' }
SeqDataStream class >> block: aGeneratorBlock [
	^self new
		block: aGeneratorBlock;
		yourself
]

{ #category : #accessing }
SeqDataStream >> block: aBlock [
	block := aBlock
]

{ #category : #accessing }
SeqDataStream >> next [
	^block value.
]
