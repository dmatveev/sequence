Class {
	#name : #SequenceTest,
	#superclass : #TestCase,
	#category : #'Sequence-Tests'
}

{ #category : #tests }
SequenceTest >> testBasicScene [
	| cam vis scn |
	cam := SeqBlock named: 'Camera'.
	vis := SeqBlock named: 'Visualization'.
	cam >> vis.
	scn := Sequence startingWith: cam.
   self assert: (scn includes: cam).
   self assert: (scn includes: vis).
]

{ #category : #tests }
SequenceTest >> testBasicScene2 [
	| cam pro vis scn |
	cam := SeqBlock named: 'Camera'.
	pro := SeqBlock named: 'Processing'.
	vis := SeqBlock named: 'Visualization'.
	cam >> pro >> vis.
	cam >> vis.
	scn := Sequence startingWith: cam.
   self assert: (scn includes: cam).
   self assert: (scn includes: pro).
   self assert: (scn includes: vis).
]

{ #category : #tests }
SequenceTest >> testBasicScene2Tail [
	| cam pro vis tails |
	cam := SeqBlock named: 'Camera'.
	pro := SeqBlock named: 'Processing'.
	vis := SeqBlock named: 'Visualization'.
	cam >> pro >> vis.
	cam >> vis.
	tails := (Sequence startingWith: cam) tails.
   self assert: tails size equals: 1.
   self assert: (tails includes: vis).
]

{ #category : #tests }
SequenceTest >> testBasicScene2Topo [
	| cam pro vis topo |
	cam := SeqBlock named: 'Camera'.
	pro := SeqBlock named: 'Processing'.
	vis := SeqBlock named: 'Visualization'.
	cam >> pro >> vis.
	cam >> vis.
	topo := (Sequence startingWith: cam) topoSorted.
	self assert: topo size equals: 3.
	self assert: topo equals: { cam. pro. vis } asOrderedCollection 
]

{ #category : #tests }
SequenceTest >> testBasicScene3 [
	| cam pro vis dis net tails |
	cam := SeqBlock named: 'Camera'.
	pro := SeqBlock named: 'Processing'.
	vis := SeqBlock named: 'Visualization'.
	dis := SeqBlock named: 'Display'.
	net := SeqBlock named: 'Network'.
	cam >> pro >> vis.
	cam >> vis.
	vis >> dis.
	vis >> net.
	tails := (Sequence startingWith: cam) tails.
   self assert: tails size equals: 2.
   self assert: (tails includes: dis).
   self assert: (tails includes: net).
]

{ #category : #tests }
SequenceTest >> testBasicSceneTail [
	| cam vis tails |
	cam := SeqBlock named: 'Camera'.
	vis := SeqBlock named: 'Visualization'.
	cam >> vis.
	tails := (Sequence startingWith: cam) tails.
	self assert: tails size equals: 1.
	self assert: (tails includes: vis).
]

{ #category : #tests }
SequenceTest >> testHasLiveSource [
	| cam vis  |
	cam := SeqBlock named: 'Camera'.
	vis := SeqBlock named: 'Visualization'.
	cam >> vis.
	self assert: (Sequence startingWith: cam) hasLiveSource not.
	cam live.
	self assert: (Sequence startingWith: cam) hasLiveSource.
	

]

{ #category : #tests }
SequenceTest >> testSceneRecursion [
	| cam vis |
	cam := SeqBlock named: 'Camera'.
	vis := SeqBlock named: 'Visualization'.
	cam >> vis >> cam.
	self should: [Sequence startingWith: cam] raise: SeqCycleException .
]

{ #category : #tests }
SequenceTest >> testSceneRecursion2 [
	| cam pro vis |
	cam := SeqBlock named: 'Camera'.
	pro := SeqBlock named: 'Processing'.
	vis := SeqBlock named: 'Visualization'.
	cam >> pro >> vis.
	cam >> vis.
	vis >> cam.
	self should: [Sequence startingWith: cam] raise: SeqCycleException .
]

{ #category : #tests }
SequenceTest >> testSingleItem [
	| cam scn |
	cam := SeqBlock named: 'Camera'.
	scn := Sequence startingWith: cam.
   self assert: (scn includes: cam).

]

{ #category : #tests }
SequenceTest >> testSingleItemTail [
	| cam scn |
	cam := SeqBlock named: 'Camera'.
	scn := Sequence startingWith: cam.
   self assert: (scn tails includes: cam).

]
