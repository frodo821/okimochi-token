# 交換しないと減るトークン

価値を保存できないことに意味がある、かもしれない。


- [`0x32d2769fE46649020B73Eabd5E3Fff28A4F56487`](https://mumbai.polygonscan.com/address/0x32d2769fE46649020B73Eabd5E3Fff28A4F56487): ConciliatorProxy
- [`0x89F0810725EF263ccbF88E58407583c479fb54Ed`](https://mumbai.polygonscan.com/address/0x89F0810725EF263ccbF88E58407583c479fb54Ed): AccessToken
- [`0x46eC01aC815aE6Ed7a2808f614Cf516e6A7EbD08`](https://mumbai.polygonscan.com/address/0x46eC01aC815aE6Ed7a2808f614Cf516e6A7EbD08): OkimochiToken

## コントラクトの構成

### `ConciliatorProxy`
任意のコントラクト関数を投票ベースで呼び出すことができるコントラクト。
このコントラクトのアドレスをコントラクトのOwnerにしておけば、コミュニティの投票によって管理コマンドを実行できる。

### `AccessToken`
だれが投票できるのかを管理するトークン(ERC721)。
このNFTを持っている人は、`ConciliatorProxy` に対して関数の実行を提案したり、提案に投票したりできる。

### `OkimochiToken`
お気持ちトークン(ERC20)。交換することで価値を維持できる。14日間交換されていないトークンは消滅する。
