// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract RockPaperScissors {
    constructor() {}

    enum MoveOption {
        NotRevealedYet,
        Rock,
        Paper,
        Scissors
    }

    struct GameMove {
        bytes32 commitment;
        MoveOption revealedMove;
    }

    address[2] public playerAddresses;
    uint8 internal moveCount = 0;
    mapping(address => GameMove) public gameMoves;

    /**
     * Commit a move that is secret (only you know the move)
     * @param _commitment A combination of the move itself, and a secret hashed together.
     */
    function commitMove(bytes32 _commitment) public {
        require(moveCount < 2, "Too many game moves.");
        require(
            gameMoves[msg.sender].commitment == bytes32(0),
            "You can only submit one move."
        );

        gameMoves[msg.sender] = GameMove({
            commitment: _commitment,
            revealedMove: MoveOption.NotRevealedYet
        });

        playerAddresses[moveCount] = msg.sender;
        moveCount++;
    }

    /**
     * Reveal the move committed in the commitMove, by re-providing the same move and secret.
     * Then compare the original move+secret commitment with the new move + secret from this function.
     * @param _move The move that the player originally submitted
     * @param _secret The secret that was provided as part of the commitment from commitMove.
     */
    function revealMove(MoveOption _move, bytes32 _secret) public {
        require(
            gameMoves[msg.sender].commitment != bytes32(0),
            "No committed move to reveal"
        );

        require(
            moveCount == 2,
            "Both players must commit their moves before revealing."
        );

        bytes32 calculatedCommmitment = keccak256(
            abi.encodePacked(_move, _secret)
        );

        require(
            calculatedCommmitment == gameMoves[msg.sender].commitment,
            "Wrong move or wrong pasword"
        );

        gameMoves[msg.sender].revealedMove = _move;
    }

    /**
     * See who won using the basic rules of RPS (e.g. paper beats rock)
     */
    function determineWinner() public view returns (address winner) {
        require(moveCount == 2, "Both players must commit their moves first");

        address p1Address = playerAddresses[0];
        MoveOption p1Move = gameMoves[p1Address].revealedMove;

        address p2Address = playerAddresses[1];
        MoveOption p2Move = gameMoves[p2Address].revealedMove;

        require(
            (p1Move != MoveOption.NotRevealedYet &&
                p2Move != MoveOption.NotRevealedYet),
            "Both players must reveal their moves first"
        );

        if (p1Move == p2Move) {
            return address(0);
        }

        if (p1Move == MoveOption.Scissors) {
            if (p2Move == MoveOption.Paper) {
                return p1Address;
            }
            if (p2Move == MoveOption.Rock) {
                return p2Address;
            }
        }

        if (p1Move == MoveOption.Paper) {
            if (p2Move == MoveOption.Scissors) {
                return p2Address;
            }
            if (p2Move == MoveOption.Rock) {
                return p1Address;
            }
        }

        if (p1Move == MoveOption.Rock) {
            if (p2Move == MoveOption.Scissors) {
                return p1Address;
            }
            if (p2Move == MoveOption.Paper) {
                return p2Address;
            }
        }
    }
}
