/*
 * Copyright by the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.bitcoinj.base;

import java.util.Arrays;
import java.util.Optional;

/**
 * Supported Bitcoin script types and their <i>script identifier strings</i>. The <i>script identifier string</i> for a {@code ScriptType}
 * is the "human-readable identifier string" of a <i>Script Expression</i> as defined in
 * <a href="https://github.com/bitcoin/bips/blob/master/bip-0380.mediawiki">BIP 380</a>.
 * Only the subset of identifier strings defined in
 * <a href="https://github.com/bitcoin/bips/blob/master/bip-0381.mediawiki">BIP 381</a> and
 * <a href="https://github.com/bitcoin/bips/blob/master/bip-0382.mediawiki">BIP 382</a> map to valid {@code ScriptType} instances.
 * @see <a href="https://github.com/bitcoin/bips/blob/master/bip-0380.mediawiki">BIP 380: Output Script Descriptors General Operation</a>
 * @see <a href="https://github.com/bitcoin/bips/blob/master/bip-0381.mediawiki">BIP 381: Non-Segwit Output Script Descriptors</a>
 * @see <a href="https://github.com/bitcoin/bips/blob/master/bip-0382.mediawiki">BIP 382: Segwit Output Script Descriptors</a>
 */
public enum ScriptType {
    P2PKH("pkh"),    // pay to pubkey hash (aka pay to address)
    P2PK("pk"),      // pay to pubkey
    P2SH("sh"),      // pay to script hash
    P2WPKH("wpkh"),  // pay to witness pubkey hash
    P2WSH("wsh"),    // pay to witness script hash
    P2TR("tr");      // pay to taproot

    private final String scriptIdentifierString;

    /**
     * @param id script identifier string
     */
    ScriptType(String id) {
        this.scriptIdentifierString = id;
    }

    /**
     * Use this method to create a {@code ScriptType} from a known good <i>script identifier string</i>.
     * @param id A script identifier string
     * @return the script type
     * @throws IllegalArgumentException if unknown/invalid script identifier string
     */
    public static ScriptType of(String id) {
        return find(id)
                .orElseThrow(() -> new IllegalArgumentException("Unknown ScriptType ID"));
    }

    /**
     * Use this method to create a {@code ScriptType} from a <i>script identifier string</i> that should be
     * validated.
     * @param id A script identifier string
     * @return A {@code ScriptType}-containing {@code Optional} or {@link Optional#empty()}
     */
    public static Optional<ScriptType> find(String id) {
        return Arrays.stream(values())
                .filter(v -> v.id().equals(id))
                .findFirst();
    }

    /**
     * Return the <i>script identifier string</i> for this {@code ScriptType}.
     * <p>
     * Be careful: the {@link #id()} method returns a different type and value than what is in the {@code deprecated} {@link #id} field.
     * @return A <i>script identifier string</i>
     */
    public String id() {
        return scriptIdentifierString;
    }

}
