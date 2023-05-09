Class {
	#name : #SeqMailbox,
	#superclass : #Object,
	#instVars : [
		'storage',
		'capacity',
		'items'
	],
	#category : #Sequence
}

{ #category : #accessing }
SeqMailbox class >> options: seqExecOptions [
	^self new
		capacity: seqExecOptions mailboxSize;
		yourself
]

{ #category : #initialization }
SeqMailbox >> capacity: aNumber [
	capacity := aNumber
]

{ #category : #initialization }
SeqMailbox >> hasContent [
	^storage isEmpty not
]

{ #category : #initialization }
SeqMailbox >> hasFreeSpace [
	^items < capacity
]

{ #category : #initialization }
SeqMailbox >> initialize [
	super initialize.
	storage := DoubleLinkedList new.
	capacity := 1.
	items := 0.
]

{ #category : #initialization }
SeqMailbox >> put: aFrame [
	self assert: self hasFreeSpace.
	storage add: aFrame.
	items := items + 1.
]

{ #category : #initialization }
SeqMailbox >> takeOne [
	| item |
	self assert: self hasContent.
	item := storage first.
	storage removeFirst.
	items := items - 1.
	^item
]
