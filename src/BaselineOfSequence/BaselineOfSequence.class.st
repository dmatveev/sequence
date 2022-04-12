Class {
	#name : #BaselineOfSequence,
	#superclass : #BaselineOf,
	#category : #BaselineOfSequence
}

{ #category : #baselines }
BaselineOfSequence >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ "Dependencies"
				spec baseline: 'Roassal3' with: [ spec repository: 'github://ObjectProfile/Roassal3' ].
				spec package: 'Sequence'.
				spec package: 'Sequence-Tests' with: [ spec requires: #('Sequence') ]]
]
